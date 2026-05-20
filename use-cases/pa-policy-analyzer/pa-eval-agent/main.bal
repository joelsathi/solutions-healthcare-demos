import ballerina/ai;
import ballerina/http;

listener ai:Listener agentListener = new (listenOn = check http:getDefaultListener());

service /GapEvalAgent on agentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string evalId = request.sessionId;
        EvalParams|error evalParams = dbClient->queryRow(
            `SELECT patient_id AS patientId, patient_name AS patientName, policy_id AS policyId, cpt_code AS cptCode, 
                    cpt_description AS cptDescription, payer, status
            FROM evaluations WHERE id = ${evalId}`, EvalParams
        );

        if evalParams is error {
            return {
                message: "Error: Evaluation not found for ID " + evalId
            };
        }

        setEvalContext(request.sessionId, {
            evaluationId: evalId,
            patientId: evalParams.patientId,
            policyId: evalParams.policyId,
            resultSortOrder: 0
        });

        _ = start runAgentAsync(request.sessionId, request.message, evalParams.patientName, evalParams.cptCode, evalParams.payer, evalId);

        return { 
            message: string `Evaluation started for ${evalParams.patientName} (${evalParams.cptCode}) under ${evalParams.payer}. 
                    You will receive updates as the evaluation progresses.`
        };
    }
}
