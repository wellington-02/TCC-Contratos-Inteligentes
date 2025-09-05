pragma solidity >=0.6.2 <0.9.0;

// Compat layer p/ projetos que importam `ds-test/test.sol`.
// Redireciona p/ forge-std mantendo o nome `DSTest`.
import "forge-std/Test.sol";
contract DSTest is Test {}
