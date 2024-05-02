// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RebaseLib} from "../src/RebaseLib.sol";

contract RebaseLibTest is Test {
    RebaseLib.RebaseData rebaseData;

    function setUp() public {
        rebaseData.totalShares = 0;
        rebaseData.pooledValue = 0;
    }

    function testMintShares() public {
        address user = address(0x2);
        uint256 amount = 500;
        RebaseLib.mintShares(rebaseData, user, amount);
        assertEq(rebaseData.shares[user], amount, "Minting shares failed");
        assertEq(rebaseData.totalShares, amount, "Total shares not updated correctly");
    }

    function testBurnShares() public {
        address user = address(0x3);
        uint256 mintAmount = 300;
        uint256 burnAmount = 200;
        RebaseLib.mintShares(rebaseData, user, mintAmount);
        RebaseLib.burnShares(rebaseData, user, burnAmount);
        assertEq(rebaseData.shares[user], mintAmount - burnAmount, "Burning shares failed");
        assertEq(
            rebaseData.totalShares,
            mintAmount - burnAmount,
            "Total shares not updated correctly after burn"
        );
    }

    function testUpdatePooledValuePositive() public {
        uint256 delta = 1000;
        RebaseLib.updatePooledValue(rebaseData, true, delta);
        assertEq(rebaseData.pooledValue, delta, "Supply not updated correctly");
    }

    function testUpdatePooledValueNegative() public {
        uint256 initialSupply = 5000;
        uint256 delta = 1000;
        rebaseData.pooledValue = initialSupply;
        RebaseLib.updatePooledValue(rebaseData, false, delta);
        assertEq(rebaseData.pooledValue, initialSupply - delta, "Supply not decreased correctly");
    }

    function testSharesOf() public {
        address user = address(0x4);
        uint256 amount = 600;
        RebaseLib.mintShares(rebaseData, user, amount);
        uint256 shares = RebaseLib.sharesOf(rebaseData, user);
        assertEq(shares, amount, "Shares of user incorrect");
    }

    function testGetPooledValue() public {
        uint256 initialSupply = 7000;
        rebaseData.pooledValue = initialSupply;
        uint256 pooledValue = RebaseLib.getPooledValue(rebaseData);
        assertEq(pooledValue, initialSupply, "Pooled value incorrect");
    }

    function testGetTotalShares() public {
        uint256 amount = 800;
        address user = address(0x5);
        RebaseLib.mintShares(rebaseData, user, amount);
        uint256 totalShares = RebaseLib.getTotalShares(rebaseData);
        assertEq(totalShares, amount, "Total shares incorrect");
    }

    function testCalculateBalance() public {
        address user = address(0x1);
        uint256 mintAmount = 1000;
        uint256 pooledValue = 5000;
        rebaseData.totalShares = mintAmount;
        rebaseData.pooledValue = pooledValue;
        RebaseLib.mintShares(rebaseData, user, mintAmount);
        uint256 balance = RebaseLib.calculateBalance(rebaseData, rebaseData.shares[user]);
        uint256 expectedBalance = (mintAmount * pooledValue) / rebaseData.totalShares;
        assertEq(balance, expectedBalance, "Calculated balance incorrect");
    }

    function testBalanceUpdateOnSupplyIncrease() public {
        address user = address(0x2);
        uint256 mintAmount = 500;
        uint256 pooledValue = 10000;
        uint256 increaseAmount = 2000;

        RebaseLib.mintShares(rebaseData, user, mintAmount);
        rebaseData.pooledValue = pooledValue;
        RebaseLib.updatePooledValue(rebaseData, true, increaseAmount);

        uint256 expectedBalance = (mintAmount * (pooledValue + increaseAmount)) /
            rebaseData.totalShares;
        uint256 balance = RebaseLib.calculateBalance(rebaseData, rebaseData.shares[user]);

        assertEq(balance, expectedBalance, "Balance not updated correctly after supply increase");
    }

    function testBalanceUpdateOnSupplyDecrease() public {
        address user = address(0x3);
        uint256 mintAmount = 700;
        uint256 pooledValue = 15000;
        uint256 decreaseAmount = 3000;

        RebaseLib.mintShares(rebaseData, user, mintAmount);
        rebaseData.pooledValue = pooledValue;
        RebaseLib.updatePooledValue(rebaseData, false, decreaseAmount);

        uint256 expectedBalance = (mintAmount * (pooledValue - decreaseAmount)) /
            rebaseData.totalShares;
        uint256 balance = RebaseLib.calculateBalance(rebaseData, rebaseData.shares[user]);

        assertEq(balance, expectedBalance, "Balance not updated correctly after supply decrease");
    }

    function testTransferShares() public {
        address sender = address(0x4);
        address receiver = address(0x5);
        uint256 initialSenderShares = 1000;
        uint256 transferAmount = 300;

        rebaseData.shares[sender] = initialSenderShares;
        rebaseData.totalShares = initialSenderShares;

        RebaseLib.transferShares(rebaseData, sender, receiver, transferAmount);

        uint256 expectedSenderFinalShares = initialSenderShares - transferAmount;
        uint256 expectedReceiverFinalShares = transferAmount;
        assertEq(
            rebaseData.shares[sender],
            expectedSenderFinalShares,
            "Sender shares incorrect after transfer"
        );
        assertEq(
            rebaseData.shares[receiver],
            expectedReceiverFinalShares,
            "Receiver did not receive correct shares"
        );

        assertEq(
            rebaseData.totalShares,
            initialSenderShares,
            "Total shares should not change after transfer"
        );
    }
}
