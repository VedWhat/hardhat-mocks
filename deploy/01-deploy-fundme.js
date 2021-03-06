const { network } = require("hardhat")
const { networkConfig } = require("./helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const chainId = network.config.chainId
    const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]

    //Local host will be using mocking
    if (chainId == "31337") {
        const fundMe = await deploy("FundMe", {
            from: deployer,
            args: [address],
            log: true,
        })
    }
}
