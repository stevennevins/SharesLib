// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SharesLib} from "../src/SharesLib.sol";

contract RebaseLibTest is Test {
    SharesLib.SharesData sharesData;

    function setUp() public {
        sharesData.totalShares = 0;
        sharesData.pooledValue = 0;
    }

    function testMintShares() public {
        address user = address(0x2);
        uint256 amount = 500;
        SharesLib.mintShares(sharesData, user, amount);
        assertEq(sharesData.shares[user], amount, "Minting shares failed");
        assertEq(sharesData.totalShares, amount, "Total shares not updated correctly");
    }

    function testBurnShares() public {
        address user = address(0x3);
        uint256 mintAmount = 300;
        uint256 burnAmount = 200;
        SharesLib.mintShares(sharesData, user, mintAmount);
        SharesLib.burnShares(sharesData, user, burnAmount);
        assertEq(sharesData.shares[user], mintAmount - burnAmount, "Burning shares failed");
        assertEq(
            sharesData.totalShares,
            mintAmount - burnAmount,
            "Total shares not updated correctly after burn"
        );
    }

    function testUpdatePooledValuePositive() public {
        uint256 delta = 1000;
        SharesLib.updatePooledValue(sharesData, true, delta);
        assertEq(sharesData.pooledValue, delta, "Supply not updated correctly");
    }

    function testUpdatePooledValueNegative() public {
        uint256 initialSupply = 5000;
        uint256 delta = 1000;
        sharesData.pooledValue = initialSupply;
        SharesLib.updatePooledValue(sharesData, false, delta);
        assertEq(sharesData.pooledValue, initialSupply - delta, "Supply not decreased correctly");
    }

    function testSharesOf() public {
        address user = address(0x4);
        uint256 amount = 600;
        SharesLib.mintShares(sharesData, user, amount);
        uint256 shares = SharesLib.sharesOf(sharesData, user);
        assertEq(shares, amount, "Shares of user incorrect");
    }

    function testGetPooledValue() public {
        uint256 initialSupply = 7000;
        sharesData.pooledValue = initialSupply;
        uint256 pooledValue = SharesLib.getPooledValue(sharesData);
        assertEq(pooledValue, initialSupply, "Pooled value incorrect");
    }

    function testGetTotalShares() public {
        uint256 amount = 800;
        address user = address(0x5);
        SharesLib.mintShares(sharesData, user, amount);
        uint256 totalShares = SharesLib.getTotalShares(sharesData);
        assertEq(totalShares, amount, "Total shares incorrect");
    }

    function testCalculateBalance() public {
        address user = address(0x1);
        uint256 mintAmount = 1000;
        uint256 pooledValue = 5000;
        sharesData.totalShares = mintAmount;
        sharesData.pooledValue = pooledValue;
        SharesLib.mintShares(sharesData, user, mintAmount);
        uint256 balance = SharesLib.calculateBalance(sharesData, sharesData.shares[user]);
        uint256 expectedBalance = (mintAmount * pooledValue) / sharesData.totalShares;
        assertEq(balance, expectedBalance, "Calculated balance incorrect");
    }

    function testBalanceUpdateOnSupplyIncrease() public {
        address user = address(0x2);
        uint256 mintAmount = 500;
        uint256 pooledValue = 10000;
        uint256 increaseAmount = 2000;

        SharesLib.mintShares(sharesData, user, mintAmount);
        sharesData.pooledValue = pooledValue;
        SharesLib.updatePooledValue(sharesData, true, increaseAmount);

        uint256 expectedBalance = (mintAmount * (pooledValue + increaseAmount)) /
            sharesData.totalShares;
        uint256 balance = SharesLib.calculateBalance(sharesData, sharesData.shares[user]);

        assertEq(balance, expectedBalance, "Balance not updated correctly after supply increase");
    }

    function testBalanceUpdateOnSupplyDecrease() public {
        address user = address(0x3);
        uint256 mintAmount = 700;
        uint256 pooledValue = 15000;
        uint256 decreaseAmount = 3000;

        SharesLib.mintShares(sharesData, user, mintAmount);
        sharesData.pooledValue = pooledValue;
        SharesLib.updatePooledValue(sharesData, false, decreaseAmount);

        uint256 expectedBalance = (mintAmount * (pooledValue - decreaseAmount)) /
            sharesData.totalShares;
        uint256 balance = SharesLib.calculateBalance(sharesData, sharesData.shares[user]);

        assertEq(balance, expectedBalance, "Balance not updated correctly after supply decrease");
    }

    function testTransferShares() public {
        address sender = address(0x4);
        address receiver = address(0x5);
        uint256 initialSenderShares = 1000;
        uint256 transferAmount = 300;

        sharesData.shares[sender] = initialSenderShares;
        sharesData.totalShares = initialSenderShares;

        SharesLib.transferShares(sharesData, sender, receiver, transferAmount);

        uint256 expectedSenderFinalShares = initialSenderShares - transferAmount;
        uint256 expectedReceiverFinalShares = transferAmount;
        assertEq(
            sharesData.shares[sender],
            expectedSenderFinalShares,
            "Sender shares incorrect after transfer"
        );
        assertEq(
            sharesData.shares[receiver],
            expectedReceiverFinalShares,
            "Receiver did not receive correct shares"
        );

        assertEq(
            sharesData.totalShares,
            initialSenderShares,
            "Total shares should not change after transfer"
        );
    }
}
