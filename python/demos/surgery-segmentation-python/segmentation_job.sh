
# Store input arguments: <output_directory> <device> <fp_precision> <input_file>
OUTPUT_FILE=$1
DEVICE=$2
FP_MODEL=$3
INPUT_FILE=$4

# The default path for the job is the user's home directory,
#  change directory to where the files are.
cd $PBS_O_WORKDIR

# Make sure that the output directory exists.
mkdir -p $OUTPUT_FILE

# Check for special setup steps depending upon device to be used
if [ "$DEVICE" = "HETERO:FPGA,CPU" ]; then
    # Environment variables and compilation for edge compute nodes with FPGAs
    source /opt/altera/aocl-pro-rte/aclrte-linux64/init_opencl.sh
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/intel/openvino/bitstreams/a10_vision_design_sg1_bitstreams/BSP/a10_1150_sg1/linux64/lib
    aocl program acl0 /opt/intel/openvino/bitstreams/a10_vision_design_sg1_bitstreams/2019R4_PL1_FP11_ResNet_VGG.aocx
    export CL_CONTEXT_COMPILER_MODE_INTELFPGA=3
fi

# Set inference model IR files using specified precision
#MODELPATH=models/intel/TODO/${FP_MODEL}/TODO.xml

# Run the robotic surgery segmentation code

python3 python/segmentation_parts.py  -m $FP_MODEL \
                                      -i $INPUT_FILE \
                                      -d $DEVICE \
                                      -o $OUTPUT_FILE
