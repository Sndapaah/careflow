const Diagnosis = require("../models/diagnosis");

const getDiagnosisHistory = async (req, res) => {

    try {

        const history = await Diagnosis.find({
            patient: req.user._id
        })
        .populate(
            "recommendedHospitals",
            "name city rating emergency averageWaitingTime"
        )
        .sort({
            createdAt: -1
        });

        return res.status(200).json({
            success: true,
            count: history.length,
            history
        });

    } catch (error) {

        console.log(error);

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

module.exports = {
    getDiagnosisHistory
};