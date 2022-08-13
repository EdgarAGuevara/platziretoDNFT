// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PokeNFT is ERC721, ERC721URIStorage, Ownable, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIdCounter;

    string[] uriData = [
        "https://gateway.pinata.cloud/ipfs/QmdpoUVppp7eHasfyJr3FxXXNrzRrxkkXbafdkgCJuesWZ",
        "https://gateway.pinata.cloud/ipfs/QmZo1jFKMaj5TzaiczXn13C37F198Z1PAopVKQBwbGD9ct",
        "https://gateway.pinata.cloud/ipfs/Qmf3N5x8bdksbw5dgKYZgnMY44L1uyQqKuX3LdfyfpvxuM",
        "https://gateway.pinata.cloud/ipfs/QmZEbgUgpw9NC7fPmBE3WfrQvip5bAAzcF1W7iveepLAXQ",
        "https://gateway.pinata.cloud/ipfs/QmQLXdaHQ78pRpVqZNhmDFdc8hoTLjLikYcoPCNRnNMAxe"
    ];

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(uint256 _interval) ERC721("PokeNFT", "POKFT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        override
        returns (bool unkeepNeeded, bytes memory /* performData */)
    {
        uint256 tokenId = tokenIdCounter.current() - 1;
        bool done;
        if (getStage(tokenId) >= 4) {
            done = true;
        }
        unkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            uint256 tokenId = tokenIdCounter.current() - 1;
            updateToken(tokenId);
        }
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uriData[0]);
    }

    function getStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        if (compareStrings(_uri, uriData[0])) {
            return 0;
        }
        if (compareStrings(_uri, uriData[1])) {
            return 1;
        }
        if (compareStrings(_uri, uriData[2])) {
            return 2;
        }
        if (compareStrings(_uri, uriData[3])) {
            return 3;
        }
        return 4;
    }

    function updateToken(uint256 _tokenId) private {
        if (getStage(_tokenId) >= 4) {
            return;
        }

        uint256 newVal = getStage(_tokenId) + 1;
        string memory newUri = uriData[newVal];

        _setTokenURI(_tokenId, newUri);
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}