pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import './ERC721.sol';

contract CryptoBallers is ERC721 {

    struct Baller {
        string name;
        uint level;
        uint offenseSkill;
        uint defenseSkill;
        uint winCount;
        uint lossCount;
    }

    address owner;
    Baller[] public ballers;

    // Mapping for if address has claimed their free baller
    mapping(address => bool) public claimedFreeBaller;

    // Fee for buying a baller
    uint ballerFee = 0.10 ether;

    /**
    * @dev Ensures ownership of the specified token ID
    * @param _tokenId uint256 ID of the token to check
    */
    modifier onlyOwnerOf(uint256 _tokenId) {
        // TODO add your code
        msg.sender == ownerOf(_tokenId);
        _;
    }

    /**
    * @dev Ensures ownership of contract
    */
    modifier onlyOwner() {
        // TODO add your code
        msg.sender == owner;
        _;
    }

    /**
    * @dev Ensures baller has level above specified level
    * @param _level uint level that the baller needs to be above
    * @param _ballerId uint ID of the Baller to check
    */
    modifier aboveLevel(uint _level, uint _ballerId) {
        // TODO add your code
        ballers[_ballerId].level > _level;
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows user to claim first free baller, ensure no address can claim more than one
    */
    function claimFreeBaller() public {
        // TODO add your code
        require(!claimedFreeBaller[msg.sender], "address has already claimed a free baller");
        
        uint level = 1;
        (uint offense, uint defense) = _random(1,5);
        claimedFreeBaller[msg.sender] = true;
        _createBaller("puppy", level, offense, defense);
    }

    /**
    * @dev Allows user to buy baller with set attributes
    */
    function buyBaller() public payable {
        // TODO add your code
        require(msg.value >= ballerFee, "not enough ethers in transaction");
        
        uint level = 1;
        (uint offense, uint defense) = _random(1,10);
        _createBaller("puppy", level, offense, defense);
    }

    function getAllCryptoBallers(address _from) public view returns (string[], uint[5][]) {

        string[] memory name = new string[](balanceOf(_from));
        uint256[5][] memory specs = new uint256[5][](balanceOf(_from));
        uint j = 0;

        for (uint i = 0; i < ballers.length; i++) {

            if (_from == ownerOf(i)) {
                Baller storage tmp_baller = ballers[i];
                
                name[j] = tmp_baller.name;
                specs[0][j] = tmp_baller.level;
                specs[1][j] = tmp_baller.offenseSkill;
                specs[2][j] = tmp_baller.defenseSkill;
                specs[3][j] = tmp_baller.winCount;
                specs[4][j] = tmp_baller.lossCount;
                j = j.add(1);
            }
        }
        return (name, specs);
    }

    /**
    * @dev Play a game with your baller and an opponent baller
    * If your baller has more offensive skill than your opponent's defensive skill
    * you win, your level goes up, the opponent loses, and vice versa.
    * If you win and your baller reaches level 5, you are awarded a new baller with a mix of traits
    * from your baller and your opponent's baller.
    * @param _ballerId uint ID of the Baller initiating the game
    * @param _opponentId uint ID that the baller needs to be above
    */
    function playBall(uint _ballerId, uint _opponentId) onlyOwnerOf(_ballerId) public {
        // TODO add your code
        require(_ballerId != _opponentId, "a baller can't fight itself");
        require(ownerOf(_ballerId) != ownerOf(_opponentId), "can't fight your own ballers");

        Baller storage player = ballers[_ballerId];
        Baller storage opponent = ballers[_opponentId];
        
        // calculate random first strike advantage for player
        (uint firstStrikeOffense, uint firstStrikeDefense) = _random(0,3);

        if ((player.offenseSkill + firstStrikeOffense) > opponent.defenseSkill) {
            player.level = player.level.add(1);
            player.winCount = player.winCount.add(1);
            opponent.lossCount = opponent.lossCount.add(1);
        } else if ((player.defenseSkill + firstStrikeDefense) < opponent.offenseSkill) {
            opponent.level = opponent.level.add(1);
            opponent.winCount = opponent.winCount.add(1);
            player.lossCount = player.lossCount.add(1);
        }

        if (ballers[_ballerId].level == 5) {
            (uint level, uint attack, uint defense) = _breedBallers(ballers[_ballerId], ballers[_opponentId]);
            _createBaller("puppy_breed", level, attack, defense);
        }
    }

    /**
    * @dev Changes the name of your baller if they are above level two
    * @param _ballerId uint ID of the Baller who's name you want to change
    * @param _newName string new name you want to give to your Baller
    */
    function changeName(uint _ballerId, string _newName) external aboveLevel(2, _ballerId) onlyOwnerOf(_ballerId) {
        // TODO add your code
        ballers[_ballerId].name = _newName;
    }

    /**
   * @dev Creates a baller based on the params given, adds them to the Baller array and mints a token
   * @param _name string name of the Baller
   * @param _level uint level of the Baller
   * @param _offenseSkill offensive skill of the Baller
   * @param _defenseSkill defensive skill of the Baller
   */
    function _createBaller(string _name, uint _level, uint _offenseSkill, uint _defenseSkill) internal {
        // TODO add your code
        uint256 tokenId = ballers.length;
        ballers.push(Baller(_name, _level, _offenseSkill, _defenseSkill, 0, 0));
        _mint(msg.sender, tokenId);
    }

    /**
    * @dev Helper function for a new baller which averages the attributes of the level, attack, defense of the ballers
    * @param _baller1 Baller first baller to average
    * @param _baller2 Baller second baller to average
    * @return tuple of level, attack and defense
    */
    function _breedBallers(Baller _baller1, Baller _baller2) internal pure returns (uint, uint, uint) {
        uint level = _baller1.level.add(_baller2.level).div(2);
        uint attack = _baller1.offenseSkill.add(_baller2.offenseSkill).div(2);
        uint defense = _baller1.defenseSkill.add(_baller2.defenseSkill).div(2);
        return (level, attack, defense);

    }

    function _random(uint8 floor, uint8 ceiling) private view returns (uint8, uint8) {
        //TODO: build in a range for random
        uint8 offense = uint8(blockhash(block.number-1))%ceiling + floor;
        uint8 defense = uint8(blockhash(block.number-2))%ceiling + floor;
        return (offense, defense);
    }
}