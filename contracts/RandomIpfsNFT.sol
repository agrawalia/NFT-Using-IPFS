// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomIpfsNFT is ERC721URIStorage, VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface immutable i_vrfCoorrdinator;
    bytes32 immutable i_gasLane;    // PRICE PER GAS
    uint64 immutable i_subscriptionId;
    uint32 immutable i_callbackGasLimit;    // MAX GAS AMOUNT

    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint16 constant NUM_WORDS = 1;
    uint256 constant MAX_CHANCE_VALUE = 100;

    mapping(uint256 => address) s_requestIdToSender;

    uint256 s_tokenCounter;
    string[3] s_dogTokenUris;
    
    constructor (address vrfCoorrdinatorV2, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit , string[3] memory dogTokenUris) 
    ERC721("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoorrdinatorV2){
        i_vrfCoorrdinator= VRFCoordinatorV2Interface(vrfCoorrdinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenUris = dogTokenUris;

    }

    //Mint a random puppy
    function requestDoggie() public returns (uint256 requestId) {
        requestId = i_vrfCoorrdinator.requestRandomWords(i_gasLane, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS);
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
        
        //owner of the dog
        address dogOwner = s_requestIdToSender[requestId];

        //assign this NFT a tokenId
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;


        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 breed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);

        _setTokenURI(newTokenId, s_dogTokenUris[breed]);

    }

    function getChanceArray() public pure returns(uint256[3] memory){
        return [10,30,MAX_CHANCE_VALUE];


    }

    function getBreedFromModdedRng(uint256 moddedRng) public pure returns(uint256){
        uint256 cummulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();

        for(uint256 i = 0; i<chanceArray.length; i++){
            if(moddedRng >= cummulativeSum && moddedRng < cummulativeSum + chanceArray[i]){
                return i;
            }
            cummulativeSum = cummulativeSum + chanceArray[i];
        }
    }


}
