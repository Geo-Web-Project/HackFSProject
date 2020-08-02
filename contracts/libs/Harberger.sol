//Harberger Contract based on code TODD PROEBSTING work described:
//https://programtheblockchain.com/posts/2018/09/19/implementing-harberger-tax-deeds/
//Updated for Solidity 0.6.6 and other minor changes

pragma solidity ^0.6.6;

contract HarbergerTax {
    address public taxRecipient;

    // Per day tax rate
    uint256 public taxNumerator;
    uint256 public taxDenominator;
    uint256 public tokenLength;

    struct Token {
        address owner;
        uint256 price;
    }

    Token[] public tokens;

    constructor(
        uint256 numberOfTokens,
        uint256 _taxNumerator,
        uint256 _taxDenominator
    ) public {
        taxRecipient = msg.sender;
        tokenLength = numberOfTokens;
        taxNumerator = _taxNumerator;
        taxDenominator = _taxDenominator;
    }

    struct Account {
        uint256 balance;
        uint256 sumOfPrices;
        uint256 paidThru;
    }

    mapping(address => Account) public accounts;

    function taxesDue(address addr) public view returns (uint256) {
        Account storage a = accounts[addr];

        return a.sumOfPrices * (now - a.paidThru) * taxNumerator
            / taxDenominator / 1 days;
    }

    event Change(uint256 indexed id, address indexed to, address indexed from);

    // Possibly foreclose on token[id]
    function forecloseIfPossible(uint256 id) public {
        Token storage t = tokens[id];
        Account storage a = accounts[t.owner];

        // Owner must be broke and behind on taxes to foreclose
        if (a.balance == 0 && a.paidThru < now && a.sumOfPrices > 0) {
            a.sumOfPrices -= t.price;
            emit Change(id, address(0x0), t.owner);
            delete(tokens[id]);
        }
    }

    // Collect taxes due from account.
    // Return true if taxes fully paid, false otherwise
    function collectTaxes(address addr) public returns (bool) {
        Account storage a = accounts[addr];

        uint256 taxes = taxesDue(addr);
        if (taxes <= a.balance) {
            a.paidThru = uint112(now);
            accounts[taxRecipient].balance += taxes;
            a.balance -= taxes;
            return true;
        } else {
            // Adjust paidThru proportionally (overflow check unnecessary)
            a.paidThru += uint112((now - a.paidThru) * a.balance / taxes);

            // Collect entire balance for partially-paid taxes
            accounts[taxRecipient].balance += a.balance;
            a.balance = 0;
            return false;
        }
    }

    // Try to buy token for no more than 'max'
    function buy(
        uint256 id,
        uint256 max,
        uint256 price
    )
        public
        payable
        returns (bool)
    {
        accounts[msg.sender].balance += msg.value;

        Token storage t = tokens[id];

        // Collect taxes from token's owner and possibly foreclose on token[id].
        collectTaxes(t.owner);

        // Foreclosure may change price and seller.
        forecloseIfPossible(id);
        address seller = t.owner;

        if (seller != msg.sender) {
            require(max >= t.price, "price is too high");

            // Collect taxes due from buyer before checking their balance
            collectTaxes(msg.sender);
            require(accounts[msg.sender].balance >= t.price,
                "insufficient funds");

            // Transfer purchase price
            accounts[seller].balance += t.price;
            accounts[msg.sender].balance -= t.price;

            t.owner = msg.sender;
        }
        // Adjust buyer's and seller's sumOfPrices
        accounts[seller].sumOfPrices -= t.price;
        accounts[msg.sender].sumOfPrices += price;

        t.price = price;

        emit Change(id, msg.sender, seller);

        return true;
    }

    function deposit() public payable {
        accounts[msg.sender].balance += msg.value;
    }

    function withdraw(uint256 amount) public {
        collectTaxes(msg.sender);

        require(accounts[msg.sender].balance >= amount, "insufficient funds");

        accounts[msg.sender].balance -= amount;
        msg.sender.transfer(amount);
    }

    function tokenCount() public view returns (uint256) {
        return tokens.length;
    }

    address public newRecipient;

      function approveRecipient(address _newRecipient) public {
        require(msg.sender == taxRecipient, "must be taxRecipient");
        newRecipient = _newRecipient;
    }

    function transferRecipient() public {
        require(msg.sender == newRecipient, "must be approved");
        taxRecipient = msg.sender;
        newRecipient = address(0x0);
    }
}
