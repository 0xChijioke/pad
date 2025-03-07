// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

import { IVesting } from "./IVesting.sol";

contract VestingManager is AccessControl {}