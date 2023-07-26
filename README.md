# USBT

Unversal Soulbound Token.  
One ERC721 Soulbound Token for each account, claimable and burnable.

## Installation:

- Run `forge install https://github.com/eldief/USBT`  
- Configure remappings in `foundry.toml`: `remappings = ["usbt/=lib/USBT/src/"]`  
- Import `import {USBT} from "usbt/USBT.sol";`  
- Inherit `contract MyUSBT is USBT { ... }`
- Initialiaze `constructor() USBT("My USBT", "MYUSBT") { ... }`

## Built with USBT:

[Universal Opepen](https://github.com/eldief/u-opepen)
