// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SharesLib {
    struct SharesData {
        mapping(address => uint256) shares;
        uint256 totalShares;
        uint256 pooledValue;
    }

    function mintShares(SharesData storage data, address to, uint256 amount) internal {
        data.shares[to] += amount;
        data.totalShares += amount;
    }

    function burnShares(SharesData storage data, address from, uint256 amount) internal {
        data.totalShares -= amount;
        data.shares[from] -= amount;
    }

    function transferShares(
        SharesData storage data,
        address from,
        address to,
        uint256 amount
    ) internal {
        data.shares[to] += amount;
        data.shares[from] -= amount;
    }

    function updatePooledValue(SharesData storage data, bool isPositive, uint256 delta) internal {
        if (isPositive) {
            data.pooledValue += delta;
        } else {
            data.pooledValue -= delta;
        }
    }

    function sharesOf(SharesData storage data, address account) internal view returns (uint256) {
        return data.shares[account];
    }

    function getPooledValue(SharesData storage data) internal view returns (uint256) {
        return data.pooledValue;
    }

    function getTotalShares(SharesData storage data) internal view returns (uint256) {
        return data.totalShares;
    }

    function calculateBalance(
        SharesData storage data,
        uint256 shares
    ) internal view returns (uint256) {
        return (shares * data.pooledValue) / data.totalShares;
    }

    function calculateShares(
        SharesData storage data,
        uint256 amount
    ) internal view returns (uint256) {
        return (amount * data.totalShares) / data.pooledValue;
    }
}
