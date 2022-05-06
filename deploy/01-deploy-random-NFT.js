module.exports = async function(hre) {
    const {getNamedAccounts, deployments} = hre;
    const {deployer} = await getNamedAccounts();
    const {deploy, log} = deployments;
    const chainId = network.config.chainId;

    let vrfCoordinatorV2Address, subscrptionId
}