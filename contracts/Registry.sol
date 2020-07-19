pragma solidity ^0.6.6;

contract Registry {
    address public admin;
    
    struct LandParcel {
        address owner;
        bytes32 cid;
    }
    
    constructor() public {
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Err: Must be Admin");
        _;
    }
    
    mapping(uint256 => LandParcel) landParcels;     // GeoHash -> LandParcel
    
    function claim(uint256 _geohash, address _owner, bytes32 _cid) onlyAdmin external {
        require(landParcels[_geohash].owner == address(0), "Err: Land already Claimed");
        landParcels[_geohash] = LandParcel(_owner, _cid);
    }
    
    function owner(uint256 _geohash) external view returns (address _owner) {
        _owner = landParcels[_geohash].owner;
    }
    
    function contentIdentifier(uint256 _geohash) external view returns (bytes32  _content) {
        return landParcels[_geohash].cid;
    }
    
    function transferOwnership(uint256 _geohash, address _newOwner) external {
        require(msg.sender == landParcels[_geohash].owner, "Err: Must be Owner");
        landParcels[_geohash].owner = _newOwner;
    }
}