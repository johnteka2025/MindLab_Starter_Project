const { buildDatasetRecord } = require("./ai_dataset_export_v2");

function buildDatasetExport(inputs) {
    if (!Array.isArray(inputs)) {
        throw new Error("STOP: dataset export inputs missing");
    }

    return {
        version: "2.0",
        exportType: "ai-ready-training-dataset",
        records: inputs.map(item => buildDatasetRecord(item))
    };
}

module.exports = { buildDatasetExport };
