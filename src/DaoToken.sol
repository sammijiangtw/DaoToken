// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/Script.sol";

contract DaoToken is ERC20("Dao Token", "DaoToken") {

    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
        //_delegates[_to] 如果原本沒有值，就會是address(0)
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    function burn(address _from, uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
        _moveDelegates(_delegates[_from], address(0), _amount);
    }

    //代理人映射（被代理人 => 代理者delegatee）
    mapping(address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    //0, hacker, 1000
    function _moveDelegates(address from, address to, uint256 amount) internal {
        // 第一次mint 而且之前沒有delegatee 就會不進以下function
        if (from != to && amount > 0) {
            if (from != address(0)) {
                uint32 fromNum = numCheckpoints[from];
                uint256 fromOld = fromNum > 0 ? checkpoints[from][fromNum - 1].votes : 0;
                uint256 fromNew = fromOld - amount;
                // console.log("_moveDelegates address from", from);
                // console.log("_moveDelegates address from fromNum", fromNum);
                // console.log("_moveDelegates address from fromOld", fromOld);
                // console.log("_moveDelegates address from fromNew", fromNew);
                _writeCheckpoint(from, fromNum, fromOld, fromNew);
            }

            if (to != address(0)) {
                uint32 toNum = numCheckpoints[to];//0
                uint256 toOld = toNum > 0 ? checkpoints[to][toNum - 1].votes : 0;//0
                uint256 toNew = toOld + amount;//1000
                // console.log("_moveDelegates address to", to);
                // console.log("_moveDelegates address to toNum", toNum);
                // console.log("_moveDelegates address to toOld", toOld);
                // console.log("_moveDelegates address to toNew", toNew);
                _writeCheckpoint(to, toNum, toOld, toNew);
            }
        }
    }

    // 用戶所有的投票快照紀錄，從0開始
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
    // 快照id, 每次有新的快照，則id+1，id 從1開始
    mapping(address => uint32) public numCheckpoints;

    function delegates(address _addr) external view returns (address) {
        return _delegates[_addr];
    }

    function delegate(address _addr) external {
        return _delegate(msg.sender, _addr);
    }


    function getVotes(address _addr) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[_addr];
        return nCheckpoints > 0 ? checkpoints[_addr][nCheckpoints - 1].votes : 0;
    }

    function _delegate(address _addr, address delegatee) internal {
        address currentDelegate = _delegates[_addr];
        uint256 _addrBalance = balanceOf(_addr);
        _delegates[_addr] = delegatee;
        _moveDelegates(currentDelegate, delegatee, _addrBalance);
    }

    // 記錄投票快照，//hacker, 0, 0, 1000
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
        uint32 blockNumber = uint32(block.number);

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            
            // console.log("nCheckpoints>0", delegatee);
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
            

        } else {
            // console.log("nCheckpoints==0", delegatee);
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
            // console.log("nCheckpoints", numCheckpoints[delegatee]);
        }
    }
}