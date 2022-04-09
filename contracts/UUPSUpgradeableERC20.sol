pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/**
 * @title MyToken
 * @dev ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract UUPSUpgradeableERC20Token is Initializable, UUPSUpgradeable, OwnableUpgradeable, AccessControlUpgradeable, ERC20Upgradeable {

    uint256 private _cap;
    uint256 private _minimumSupply;
    address private _owner;
    mapping(address => uint256) private _balances;

    /**
     * @dev Gives holder all of existing tokens.
     */
    function initialize(string memory name, string memory symbol, uint256 cap, uint256 minimumSupply) external initializer {
        require(minimumSupply <= cap);
        _owner = msg.sender;
        __ERC20_init(name, symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _cap = cap * (10 ** 18);
        _mint(msg.sender, minimumSupply * (10 ** 18));
        _minimumSupply = minimumSupply * (10 ** 18);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function transfer(address to, uint256 amount) public override returns (bool) {
        return super.transfer(to, _partialBurn(amount));
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        return super.transferFrom(from, to, _partialBurn(amount));
    }

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function burn(address account, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(totalSupply() - amount >= _minimumSupply, "ERC20Upgradeable: totalSupply is less than minimumSupply");
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20Upgradeable.totalSupply() + amount <= cap(), "ERC20Upgradeable: cap exceeded");
        super._mint(account, amount);
    }

    function _partialBurn(uint256 amount) internal returns (uint256) {
        uint256 burnAmount = _calculateBurnAmount(amount);

        if (burnAmount > 0) {
            _burn(msg.sender, burnAmount);
        }

        return amount - burnAmount;
    }

    function _calculateBurnAmount(uint256 amount) internal view returns (uint256) {
        uint256 burnAmount = 0;

        // burn amount calculations
        if (totalSupply() > _minimumSupply) {
            burnAmount = amount / uint256(10);
            uint256 availableBurn = totalSupply() - _minimumSupply;
            if (burnAmount > availableBurn) {
                burnAmount = availableBurn;
            }
        }

        return burnAmount;
    }
}
