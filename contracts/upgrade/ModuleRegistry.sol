pragma solidity ^0.5.4;
import "../interfaces/Module.sol";
import "../base/Owned.sol";
import "../exchange/ERC20.sol";

/**
 * @title ModuleRegistry
 * @dev Registry of authorised modules. 
 * Modules must be registered before they can be authorised on a wallet.
 * @author Julien Niset - <julien@argent.im>
 */
contract ModuleRegistry is Owned {

    mapping (address => Info) internal modules;
    mapping (address => Info) internal upgraders;

    event ModuleRegistered(address indexed module, bytes32 name);
    event ModuleDeRegistered(address module);
    event UpgraderRegistered(address indexed upgrader, bytes32 name);
    event UpgraderDeRegistered(address upgrader);

    struct Info {
        bool exists;
        bytes32 name;
    }

    /**
     * @dev Registers a module.
     * @param _module The module.
     * @param _name The unique name of the module.
     */
    function registerModule(address _module, bytes32 _name) external onlyOwner {
        require(!modules[_module].exists, "MR: module already exists");
        modules[_module] = Info({exists: true, name: _name});
        emit ModuleRegistered(_module, _name);
    }

    /**
     * @dev Deregisters a module.
     * @param _module The module.
     */
    function deregisterModule(address _module) external onlyOwner {
        require(modules[_module].exists, "MR: module does not exists");
        delete modules[_module];
        emit ModuleDeRegistered(_module);
    }

        /**
     * @dev Registers an upgrader.
     * @param _upgrader The upgrader.
     * @param _name The unique name of the upgrader.
     */
    function registerUpgrader(address _upgrader, bytes32 _name) external onlyOwner {
        require(!upgraders[_upgrader].exists, "MR: upgrader already exists");
        upgraders[_upgrader] = Info({exists: true, name: _name});
        emit UpgraderRegistered(_upgrader, _name);
    }

    /**
     * @dev Deregisters an upgrader.
     * @param _upgrader The _upgrader.
     */
    function deregisterUpgrader(address _upgrader) external onlyOwner {
        require(upgraders[_upgrader].exists, "MR: upgrader does not exists");
        delete upgraders[_upgrader];
        emit UpgraderDeRegistered(_upgrader);
    }

    /**
    * @dev Utility method enbaling the owner of the registry to claim any ERC20 token that was sent to the
    * registry.
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external onlyOwner {
        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(msg.sender, total);
    } 

    /**
     * @dev Gets the name of a module from its address.
     * @param _module The module address.
     * @return the name.
     */
    function moduleInfo(address _module) external view returns (bytes32) {
        return modules[_module].name;
    }

    /**
     * @dev Gets the name of an upgrader from its address.
     * @param _upgrader The upgrader address.
     * @return the name.
     */
    function upgraderInfo(address _upgrader) external view returns (bytes32) {
        return upgraders[_upgrader].name;
    }

    /**
     * @dev Checks if a module is registered.
     * @param _module The module address.
     * @return true if the module is registered.
     */
    function isRegisteredModule(address _module) external view returns (bool) {
        return modules[_module].exists;
    }

    /**
     * @dev Checks if a list of modules are registered.
     * @param _modules The list of modules address.
     * @return true if all the modules are registered.
     */
    function isRegisteredModule(address[] calldata _modules) external view returns (bool) {
        for(uint i = 0; i < _modules.length; i++) {
            if (!modules[_modules[i]].exists) {
                return false;
            }
        }
        return true;
    }  

    /**
     * @dev Checks if an upgrader is registered.
     * @param _upgrader The upgrader address.
     * @return true if the upgrader is registered.
     */
    function isRegisteredUpgrader(address _upgrader) external view returns (bool) {
        return upgraders[_upgrader].exists;
    } 

}