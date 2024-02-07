// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets =   100;
    address[] public players; // Declare the players array here

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;


    // Fallback function to receive plain Ether transactions
    fallback() external payable {}

    // Receive function to handle Ether transfers
    receive() external payable {}

    // Constructor without visibility specifier
    constructor(uint256 _minimumBet) {
        owner = msg.sender;
        if (_minimumBet !=   0) minimumBet = _minimumBet;
    }

    function kill() public {
        if(msg.sender == owner) {
            // Implement a withdrawal function instead of selfdestruct
            // selfdestruct(owner);
        }
    }

    function checkPlayerExists(address player) public view returns(bool) {
        for(uint256 i =   0; i < players.length; i++) {
            if(players[i] == player) return true;
        }
        return false;
    }

    // To bet for a number between   1 and   10 both inclusive
    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "Player already exists");
        require(numberSelected >=   1 && numberSelected <=   10, "Invalid number selected");
        require(msg.value >= minimumBet, "Bet amount too low");

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;
    }

    // Generates a number between   1 and   10 that will be the winner
    function generateNumberWinner() public {
        uint256 numberGenerated = block.number %   10 +   1; // This isn't secure
        distributePrizes(numberGenerated);
    }

    // Sends the corresponding   ether to each winner depending on the total bets
    function distributePrizes(uint256 numberWinner) public {
    address[100] memory winners; // We have to create a temporary in memory array with fixed size
    uint256 count =   0; // This is the count for the array of winners
    for(uint256 i =   0; i < players.length; i++){
        address playerAddress = players[i];
        if(playerInfo[playerAddress].numberSelected == numberWinner){
            winners[count] = playerAddress;
            count++;
        }
        delete playerInfo[playerAddress]; // Delete all the players
    }
    //players.length =  0; // Clear all the players array
    uint256 winnerEtherAmount = totalBet / winners.length; // How much each winner gets
    for(uint256 j =   0; j < count; j++){
        if(winners[j] != address(0)) // Check that the address in this fixed array is not empty
            payable(winners[j]).transfer(winnerEtherAmount); // Cast to address payable before transferring
    }
}

    // Function to allow the owner to withdraw all the funds
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}