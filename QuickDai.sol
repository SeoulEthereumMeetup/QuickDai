pragma solidity ^0.4.21;

// Author: Booyoun Kim
// Date: 21 April 2018
// Version: QuickDai v0.0.1

import "./AbstractDaiToken.sol";

contract QuickDai {

	address owner;
	uint ratioOfCDP = 150;
	uint usdPriceOfETH = 584;

	mapping (address => uint256) buyerId;

	Buyer[] public buyers;

	function QuickDai() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
        if (msg.sender == owner) {
            _;
        }
    }

    struct Buyer {
		uint id;
		address addr;
		uint depositEth;
		uint drawDai;
		uint ratioOfCDP;
		bool isWipe;
	}

    function getBuyerId(address addr) constant returns (uint) {
    	return buyerId[addr];
    }

    function balanceOfDai() constant returns (uint256) {
        // DAI ERC20 Token Address : 0xc4375b7de8af5a38a93548eb8453a498222c4ff2
        DaiToken token = DaiToken(0xc4375b7de8af5a38a93548eb8453a498222c4ff2);
        return token.balanceOf(this);
    }

	// The DAI token should be sufficient for the QuickDai contract address.
	function sendToken(address toAddr, uint value) private returns (bool success) {
		DaiToken token = DaiToken(0xc4375b7de8af5a38a93548eb8453a498222c4ff2);
        require(token.transfer(toAddr, value));
        return true;
	}

 	function setUsdPriceOfETH(uint value) onlyOwner returns (bool success) {
 		usdPriceOfETH = value;
 		return true;
 	}

 	function getUsdPriceOfETH() constant returns (uint) {
 		return usdPriceOfETH;
 	}

 	function setRatioOfCDP(uint value) onlyOwner returns (bool success) {
 		ratioOfCDP = value;
 		return true;
 	}

 	function getRatioOfCDP() constant returns (uint) {
 		return ratioOfCDP;
 	}

 	function withdrawEthForOwner(uint amount) onlyOwner returns (bool success) {
 		owner.transfer(amount);
 		return true;
 	}

 	function withdrawDaiForOwner(uint amount) onlyOwner returns (bool success) {
 		sendToken(owner, amount);
 		return true;
 	}

 	// A function to execute after confirming that the DAI amount received from the DAI has been deposited. 
 	// Assume that completePayBack is true if you have confirmed payment of the loan from an external server.
 	function withdrawEth(bool completePayBack, address addr) returns (bool success) {
 		// if (msg.sender != myExternalServerAddr) {
 		// 	return;
 		// }

 		if (!completePayBack) {
 			return false;
 		}

 		addr.transfer(buyers[buyerId[addr]].depositEth);
 		buyers[buyerId[addr]].isWipe = true;
 		return true;
 	}

 	// Send DAI when you receive it.
 	function () payable {
		// 1 * 572 / 150 = 327
		// buyerId[msg.sender] If it already exists ... you need to add some code to prevent it from being duplicated later.
		if (msg.value > 0) {
			uint calDai = msg.value * usdPriceOfETH / ratioOfCDP * 100;

			buyers.length += 1;
			uint id = buyers.length - 1;

			buyerId[msg.sender] = id;
			
			buyers[id].id 	= id;
			buyers[id].addr = msg.sender;
			buyers[id].depositEth = msg.value;
			buyers[id].drawDai = calDai;
			buyers[id].ratioOfCDP = ratioOfCDP;
			buyers[id].isWipe = false;

			sendToken(msg.sender, calDai);
		}
 	}
}
