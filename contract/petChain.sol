// SPDX-License-Identifier: GPL-3.0 ccr
pragma solidity >=0.5.0;

contract petChain {
    uint32 public pet_id = 0;
    uint32 public partipant_id = 0;
    uint32 public owner_id = 0;
    
    /* 1.宠物 */
    struct pet {
        string petName;
        string health;
        address petOwner;
        uint32 cost;
        uint32 mfgTimeStamp;
    }
    mapping(uint32 => pet ) public pets;

    /* 2.参与者 */
    struct participant {
        string userName;
        string password;
        string participantType;
        address participantAdderss;
    }
    mapping(uint32 => participant ) public participants;

    /* 3.关系 */
    struct ownership {
        uint32 petId;
        uint32 ownerId;
        address petOwner;
        uint32 trxTimeStamp;
    }
    mapping(uint32 => ownership) public ownerships;

    /* 4.交易记录追踪 */
    mapping(uint32 => uint32[]) public petTrack;
    event TransferOwnership(uint32 productId);

    /* 1.添加参与者-查询参与者 */
    function addParticipant(string memory _name, string memory _pass, address _pAdd, string memory _pType) public returns (uint32) {
     uint32 userId = partipant_id++;
     participants[userId].userName = _name;
     participants[userId].password = _pass;
     participants[userId].participantAdderss = _pAdd;
     participants[userId].participantType = _pType;
    
     return userId;
    }
    function getParticipant(uint32 _pet_id) public view returns (string memory, address, string memory) {
        return (participants[_pet_id].userName,
                participants[_pet_id].participantAdderss,
                participants[_pet_id].participantType);
    }

    /* 2.添加宠物-查询宠物 */
    function addPet(uint32 _ownerId, 
                string memory _petName, 
                string memory _health,
                uint32 _cost) public returns (uint32) {
        if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("hospital")) {
            uint32 petId = pet_id++;
            
            pets[petId].petName = _petName;
            pets[petId].health = _health;
            pets[petId].cost = _cost;
            pets[petId].petOwner = participants[_ownerId].participantAdderss;
            pets[petId].mfgTimeStamp = uint32(block.timestamp);
            
            return petId;
        }
        
        return 0;
    }
    
    function getPet(uint32 _petId) public view returns (string memory, string memory, uint32,address,uint32){
        return (pets[_petId].petName,
                pets[_petId].health,
                pets[_petId].cost,
                pets[_petId].petOwner,
                pets[_petId].mfgTimeStamp);
    }
    
    /* modifier 是否为所有人 */
    modifier onlyOwner(uint32 _petId) {
        require(msg.sender == pets[_petId].petOwner, "is not owner!!!");
        _;   
    }

    /* 3.转移宠物 */
    function newOwner(uint32 _user1Id, uint32 _user2Id, uint32 _petId) onlyOwner(_petId) public returns (bool) {

        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 ownership_id = owner_id++;


           ownerships[ownership_id].petId = _petId;
           ownerships[ownership_id].ownerId = _user2Id;
           ownerships[ownership_id].petOwner = p2.participantAdderss;
           ownerships[ownership_id].trxTimeStamp = uint32(block.timestamp);

           pets[_petId].petOwner = p2.participantAdderss;
           petTrack[_petId].push(ownership_id);
           emit TransferOwnership(_petId);

      return (false);
    }
    
    /* 5.出处 */
    function getProvenance(uint32 _prodId) external view returns (uint32[] memory) {
        return petTrack[_prodId];
    }
    
    /* 6.得到关系 */
    function getOwnership(uint32 _regId) public view returns (uint32,uint32,address,uint32) {
        ownership memory r = ownerships[_regId];
        return (r.petId, r.ownerId, r.petOwner, r.trxTimeStamp);
    }
    
    

}