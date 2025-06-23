// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Script, console} from 'forge-std/Script.sol';

import {DevOpsTools} from 'foundry-devops/src/DevOpsTools.sol';
import {FundMe} from '../src/FundMe.sol';

contract FundFundMe is Script {
  uint256 constant SEND_VALUE = 0.01 ether;

  function fundFundMe(address mostRecentDeployed) public payable {
    // vm.startBroadcast();
    FundMe(payable(mostRecentDeployed)).fund{value: msg.value}();
    // vm.stopBroadcast();
    console.log('funded FundMe with %s', SEND_VALUE);
  }

  function run() external {
    address mostRecentDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
    vm.startBroadcast();
    fundFundMe(mostRecentDeployed);
    vm.stopBroadcast();
  }
}

contract WithdrawFundMe is Script {
  function withdrawFundMe(address mostRecentDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentDeployed)).withdraw();
    vm.stopBroadcast();
  }

  function run() external {
    address mostRecentDeployed = DevOpsTools.get_most_recent_deployment('FundMe', block.chainid);
    vm.startBroadcast();
    withdrawFundMe(mostRecentDeployed);
    vm.stopBroadcast();
  }
}
