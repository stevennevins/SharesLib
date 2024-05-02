// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library RebaseLib {
    struct RebaseData {
        mapping(address => uint256) shares;
        uint256 totalShares;
        uint256 pooledValue;
    }

    function mintShares(RebaseData storage data, address to, uint256 amount) internal {
        data.shares[to] += amount;
        data.totalShares += amount;
    }

    function burnShares(RebaseData storage data, address from, uint256 amount) internal {
        data.totalShares -= amount;
        data.shares[from] -= amount;
    }

    function transferShares(
        RebaseData storage data,
        address from,
        address to,
        uint256 amount
    ) internal {
        data.shares[to] += amount;
        data.shares[from] -= amount;
    }

    function updatePooledValue(RebaseData storage data, bool isPositive, uint256 delta) internal {
        if (isPositive) {
            data.pooledValue += delta;
        } else {
            data.pooledValue -= delta;
        }
    }

    function sharesOf(RebaseData storage data, address account) internal view returns (uint256) {
        return data.shares[account];
    }

    function getPooledValue(RebaseData storage data) internal view returns (uint256) {
        return data.pooledValue;
    }

    function getTotalShares(RebaseData storage data) internal view returns (uint256) {
        return data.totalShares;
    }

    function calculateBalance(
        RebaseData storage data,
        uint256 shares
    ) internal view returns (uint256) {
        return (shares * data.pooledValue) / data.totalShares;
    }

    function calculateShares(
        RebaseData storage data,
        uint256 amount
    ) internal view returns (uint256) {
        return (amount * data.totalShares) / data.pooledValue;
    }
}
