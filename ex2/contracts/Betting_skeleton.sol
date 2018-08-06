pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address public owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;
	/* Keep track of all outcomes (maps index to numerical outcome) *

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
	    require(msg.sender == owner);
	    _;
	}
	modifier OracleOnly() {
	    require(msg.sender == oracle);
	    _;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
	    owner = msg.sender;
	    outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
	    if(msg.sender == owner){
	        oracle = _oracle;
	        return oracle;
	    }
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
	    if(msg.sender == oracle || msg.sender == owner){
	        return false;
	    }
	    if(bets[msg.sender].initialized){
	        return false;
	    }
	    
	    bool isvalid;
	    for(uint i; i<outcomes.length ;i++){
	        if(outcomes[i] == _outcome){
	            isvalid = true;
	        }
	    }
	    if(!isvalid){
	        return false;
	    }
	    
	    if(!bets[gamblerA].initialized){
	        gamblerA = msg.sender;
	    }
	    else if(!bets[gamblerB].initialized){
	        gamblerB = msg.sender;
	    }
	    else {
	        return false;
	    }
	    
	    bets[msg.sender] = Bet(_outcome, msg.value, true);
	    bets[msg.sender].initialized = true;
	    BetMade(msg.sender);
	    return true;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly(){
	    if(!bets[gamblerA].initialized || !bets[gamblerB].initialized){
	        
	    }
	    else{
	        uint total = bets[gamblerA].amount + bets[gamblerB].amount;
	        if((bets[gamblerA].outcome == _outcome) && (bets[gamblerB].outcome ==_outcome)){
	         winnings[gamblerA] += bets[gamblerA].amount;
	         winnings[gamblerB] += bets[gamblerB].amount;
	        }
	        else if(bets[gamblerA].outcome == _outcome){
	            winnings[gamblerA] += total;
	        }
	        else if(bets[gamblerB].outcome == _outcome){
	            winnings[gamblerB] += total;
	        }
	        else{
	            winnings[oracle] += total;
	        }
	    }
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) payable returns (uint remainingBal) {
	    if(withdrawAmount > winnings[msg.sender]){
	        return winnings[msg.sender];
	    }
	    winnings[msg.sender] -= withdrawAmount;
	    msg.sender.transfer(withdrawAmount);
	    return winnings[msg.sender];
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
	    return outcomes;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
	    return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
	    delete(gamblerA);
	    delete(gamblerB);
	    delete(oracle);
	    delete(bets[gamblerA]);
	    delete(bets[gamblerB]);
	    BetClosed();
	}

	/* Fallback function */
	function() payable {
		revert();
	}
}

