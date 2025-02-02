const ModuleRegistry = require('../build/ModuleRegistry');
const MultiSig = require('../build/MultiSigWallet');
const GuardianManager = require('../build/GuardianManager');
const TokenExchanger = require('../build/TokenExchanger');
const LockManager = require('../build/LockManager');
const RecoveryManager = require('../build/RecoveryManager');
const TokenTransfer = require('../build/TokenTransfer');
const ApprovedTransfer = require('../build/ApprovedTransfer');
const DappManager = require('../build/DappManager');

const utils = require('../utils/utilities.js');

const DeployManager = require('../utils/deploy-manager.js');
const MultisigExecutor = require('../utils/multisigexecutor.js');

const deploy = async (network, secret) => {

    ////////////////////////////////////
    // Setup
    ////////////////////////////////////

    const manager = new DeployManager(network);
    await manager.setup();

    const configurator = manager.configurator;
    const deployer = manager.deployer;
    const versionUploader = manager.versionUploader;

    const deploymentWallet = deployer.signer;

    const config = configurator.config;
    console.log('Config:', config);

    const GuardianManagerWrapper = await deployer.wrapDeployedContract(GuardianManager, config.modules.GuardianManager);
    const LockManagerWrapper = await deployer.wrapDeployedContract(LockManager, config.modules.LockManager);
    const RecoveryManagerWrapper = await deployer.wrapDeployedContract(RecoveryManager, config.modules.RecoveryManager);
    const ApprovedTransferWrapper = await deployer.wrapDeployedContract(ApprovedTransfer, config.modules.ApprovedTransfer);
    const TokenTransferWrapper = await deployer.wrapDeployedContract(TokenTransfer, config.modules.TokenTransfer);
    const DappManagerWrapper = await deployer.wrapDeployedContract(DappManager, config.modules.DappManager);
    const TokenExchangerWrapper = await deployer.wrapDeployedContract(TokenExchanger, config.modules.TokenExchanger);

    const ModuleRegistryWrapper = await deployer.wrapDeployedContract(ModuleRegistry, config.contracts.ModuleRegistry);
    const MultiSigWrapper = await deployer.wrapDeployedContract(MultiSig, config.contracts.MultiSigWallet);

    const wrappers = [
        GuardianManagerWrapper,
        LockManagerWrapper,
        RecoveryManagerWrapper,
        ApprovedTransferWrapper,
        TokenTransferWrapper,
        DappManagerWrapper,
        TokenExchangerWrapper];

    ////////////////////////////////////
    // Register modules
    ////////////////////////////////////

    const multisigExecutor = new MultisigExecutor(MultiSigWrapper, deploymentWallet, config.multisig.autosign);

    for (let idx = 0; idx < wrappers.length; idx++) {
        let wrapper = wrappers[idx];
        await multisigExecutor.executeCall(ModuleRegistryWrapper, "registerModule", [wrapper.contractAddress, utils.asciiToBytes32(wrapper._contract.contractName)]);
    }

    ////////////////////////////////////
    // Upload Version
    ////////////////////////////////////

    const modules = wrappers.map((wrapper) => {
        return { address: wrapper.contractAddress, name: wrapper._contract.contractName };
    });
    const version = {
        modules: modules,
        fingerprint: utils.versionFingerprint(modules),
        version: "1.0.0",
        createdAt: Math.floor((new Date()).getTime() / 1000)
    }
    await versionUploader.upload(version);
};

module.exports = {
    deploy
};