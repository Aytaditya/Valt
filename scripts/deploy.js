

async function main() {

    const Paypal=await ethers.getContractFactory("Paypal");
    const paypal=await Paypal.deploy();

    await paypal.deployed();

    console.log("Paypal deployed to:", paypal.address);

}

main().catch((error)=>{    
    console.error(error);
    process.exit(1);
});

