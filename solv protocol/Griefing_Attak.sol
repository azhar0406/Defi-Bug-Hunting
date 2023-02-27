// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Target {


constructor() payable {

}

  function goTo() public {

uint256 amount = address(this).balance;
(bool success,)=payable(msg.sender).call{value: amount}("");
require(success, "low-level call failed");
  }

  receive() payable external{}
}


contract Griefing {

  Target target;

  function attack(address payable _target) public {
    target = Target(_target);

target.goTo();
  }

receive() payable external{
    revert("Not Allowed");
}

}



contract BadCoder {

  Target target;

  function attack(address payable _target) public {
    target = Target(_target);

target.goTo();
  }

receive() payable external{
    revert("Not Allowed");
}

}


contract NormalBuyer{

  Target target;

  function attack(address payable _target) public {
    target = Target(_target);

target.goTo();
  }

receive() payable external{
}

}
