
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.21 <0.7.0;

contract GeoDNS {
  address public owner;


  struct CoordinateDetails{
    uint256 radius;
    string name;
    address owner;
    uint256 price;
    string ipfsDataAddress;
    string ipfsContentAddress;
    string contentType;
  }

  mapping (uint256 => mapping (uint256 => CoordinateDetails)) locations;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner) _;
  }

    //init coordinate (only owner)
function setCoordinateStart(uint256 lat, uint256 lon, CoordinateDetails memory details) public onlyOwner  returns (bool){
    locations[lat][lon] = details;
    return true;
  }

//returns Coordinate data
  function getCoordinateInfo(uint256 lat, uint256 lon) view public returns ( CoordinateDetails memory){
    return  locations[lat][lon];
  }

  //TODO
  //after init, someone buys and sets info
  function setCoordinateUponPurchase(uint completed) public onlyOwner payable {

  }



}
