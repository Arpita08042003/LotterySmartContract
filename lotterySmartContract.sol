// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract lotterySmartContract{
    //state variable
    //manager  -->  delpoy,pickwinner,cant enter in lottery, end lottery 
    //player[] array -->  only enter onces 

    //remove infinite gas function

    address payable public  manager;
    address payable[]  players;
    uint public  amount;
    bool public completed = false;

    constructor(){
        manager = payable (msg.sender);
    }
    modifier onlyManager(){
        require(msg.sender==manager,"you are not manager");
        _;
    }
    modifier onlyPlayer(){
        require(msg.sender!=manager,"cant access as you are manager");
        _;
    }
    mapping (address=>bool) map;
    
    function checkAccessibility() private view returns(bool){
        if(map[msg.sender]) return false;
        return true;
    }

    function enter(uint _amount) public onlyPlayer  payable  {
        require(!completed,"lottery has been completed");
        require(checkAccessibility(),"already buy lottery ticket");
        (bool sent,)=manager.call{value:_amount}("");
        require(sent,"tran is failed");
        amount+=_amount;
        players.push(payable(msg.sender));
        map[msg.sender]=true;
    }

    function randMod()  private view returns(uint){
        uint randNonce = 0;
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce)));
    }

    uint _index;
    function chooseWinner() onlyManager payable public {
        _index=randMod()%players.length;
        require(!completed,"lottery has been completed");
        (bool sent,)= players[_index].call{value:amount}("");
        require(sent,"tran is failed");
        completed=true; 
         

    }

    function showWinner() public view returns(address ){
        require(completed,"lottery has not completed");
        return players[_index];

    }
    
}