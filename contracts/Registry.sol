pragma solidity ^0.6.6;

import "./libs/Harberger.sol";

contract Registry {
    address public admin;
    HarbergerTax harberger;


    struct LandParcel {
        address owner;
        string cid;
    }

    constructor() public {
        admin = msg.sender;
        harberger = new HarbergerTax(10000000000000000000, 10, 100);

    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Err: Must be Admin");
        _;
    }

    mapping(uint256 => LandParcel) landParcels;     // GeoHash -> LandParcel


    function claim(uint256 _geohash, address _owner, string calldata _cid)  payable external {


        require(landParcels[_geohash].owner == address(0), "Err: Land already Claimed");


        landParcels[_geohash] = LandParcel(_owner, _cid);
    }

    function buy(uint256 _geohash, address _owner, string calldata _cid) payable external returns(bool){

      require(harberger.buy(_geohash, msg.value, msg.value), "You do not have enough or not the right to purchase this land");
      landParcels[_geohash] = LandParcel(_owner, _cid);
      return true;

    }


    function owner(uint256 _geohash) external view returns (address _owner) {
        _owner = landParcels[_geohash].owner;
    }

    function contentIdentifier(uint256 _geohash) external view returns (string memory  _content) {
        return landParcels[_geohash].cid;
    }

    function transferOwnership(uint256 _geohash, address _newOwner) payable external {
        require(msg.sender == landParcels[_geohash].owner, "Err: Must be Owner");
        //collectTaxes(msg.sender);
        //approveRecipient(_newOwner);
        landParcels[_geohash].owner = _newOwner;
    }
}
