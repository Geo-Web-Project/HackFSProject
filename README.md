# The Geo Web HackFS Project

## Specs

Draft specifications were created for HackFS. They can be found in the [specs repo](https://github.com/Geo-Web-Project/specs)

## Components

![https://raw.githubusercontent.com/Geo-Web-Project/HackFSProject/master/Architecture.png]()

### Registry Smart Contract

The core [Registry contract](./contracts/Registry.sol) is an MVP that allows:

- Users to claim new parcels of land
- Users to specify the content identifier for a parcel of land at the time of claiming
- Users to retrieve the content identifier for any piece of land
- Users to buy someone else's land at the set Harberger value

Land is represented using Geohashes encoded as `uint256`.

### Harberger Smart Contract

The [Harberger contract](./contracts/Harberger.sol) was taken from a proof-of-concept described by [Todd Proebsting](https://programtheblockchain.com/posts/2018/09/19/implementing-harberger-tax-deeds/).

This shows the beginnings of how a Harberger tax structure may be implemented as part of the Geo Web Land Registry.

### Admin Web Interface

The repo for the Admin Web Interface can be found [here](https://github.com/Geo-Web-Project/admin-web-ui).

### iOS Browser Demo

The [iOS Browser Demo](./ios/) shows an example browser that could be implemented on top of the Geo Web. This demo:

- Looks up the CID for a parcel of land using the Registry contract on the Rinkeby network via Infura
- Resolves the CID using an IPFS Gateway
- Presents the content in various interfaces

The interfaces used to present geo-based content include:

- A foreground iOS app + UI
- Presenting iOS notifications in the background
- A foreground Apple Watch app + UI
- An Apple Watch complication that updates in the background
