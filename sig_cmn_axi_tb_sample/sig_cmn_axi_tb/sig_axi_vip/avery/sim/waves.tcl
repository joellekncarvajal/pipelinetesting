database -open waves -shm
probe -create aaxi_uvm_test_top -all -depth all -tasks -functions -shm -database waves
run
