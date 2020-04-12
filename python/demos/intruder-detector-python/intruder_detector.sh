
# Store input argumenst: <output_directory> <device> <fp_precision>
OUTPUT_FILE=$1
DEVICE=$2
FP_MODEL=$3

# The default path for the job is the user's home directory,
#  change directory to where the files are.
cd $PBS_O_WORKDIR

# Make sure that the output directory exists.
mkdir -p $OUTPUT_FILE

if [ "$DEVICE" = "HETERO:FPGA,CPU" ]; then
    # Environment variables and compilation for edge compute nodes with FPGAs
    source /opt/altera/aocl-pro-rte/aclrte-linux64/init_opencl.sh
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/intel/openvino/bitstreams/a10_vision_design_sg1_bitstreams/BSP/a10_1150_sg1/linux64/lib
    aocl program acl0 /opt/intel/openvino/bitstreams/a10_vision_design_sg1_bitstreams/2019R4_PL1_FP11_YoloV3_ELU.aocx
    export CL_CONTEXT_COMPILER_MODE_INTELFPGA=3
fi

# Choose infernece model IR files based on required precision
SAMPLEPATH=${PBS_O_WORKDIR}
if [ "$FP_MODEL" = "FP32" ]; then
  MODELPATH=${SAMPLEPATH}/models/intel/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
else
  MODELPATH=${SAMPLEPATH}/models/intel/person-vehicle-bike-detection-crossroad-0078/FP16/person-vehicle-bike-detection-crossroad-0078.xml
fi

#Running the intruder detector code
python3 intruder-detector.py -m ${MODELPATH} \
                             -lb resources/labels.txt \
                             -o $OUTPUT_FILE \
                             -d $DEVICE
