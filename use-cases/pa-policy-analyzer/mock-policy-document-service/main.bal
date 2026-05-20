import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/file;

listener http:Listener pdfServiceListener = new (6092);

const string POLICIES_DIR = "./policies/";
const string MOCK_API_KEY = "mock-api-key-12345";

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowHeaders: ["*"],
        maxAge: 84900
    }
}
service /v1 on pdfServiceListener {

    function init() {
        log:printInfo("Starting Mock PDF Service on port 6092");
    }

    // Health check — called by BFF to verify connectivity
    resource function get ping(http:Request req) returns json {
        log:printInfo("Health check ping received");
        return {"status": "ok", "service": "mock-pdf-service", "version": "1.0.0"};
    }

    // List all available PDF policy documents
    resource function get pdfs(http:Request req) returns json|http:Response|error {
        string|http:HeaderNotFoundError apiKeyHeader = req.getHeader("X-API-Key");
        if apiKeyHeader is string && apiKeyHeader != "" && apiKeyHeader != MOCK_API_KEY {
            http:Response unauthorized = new;
            unauthorized.statusCode = 401;
            unauthorized.setJsonPayload({"error": "Invalid API key"});
            return unauthorized;
        }

        log:printInfo("Listing available PDFs from policies directory");

        file:MetaData[]|file:Error dirEntries = file:readDir(POLICIES_DIR);
        if dirEntries is file:Error {
            log:printError("Failed to read policies directory: " + dirEntries.message());
            return error("Failed to read policies directory: " + dirEntries.message());
        }

        json[] pdfFiles = [];
        foreach file:MetaData entry in dirEntries {
            if !entry.dir {
                string absPath = entry.absPath;
                int? lastSlashIdx = absPath.lastIndexOf("/");
                string filename = lastSlashIdx is int ? absPath.substring(lastSlashIdx + 1) : absPath;
                if filename.endsWith(".pdf") {
                    pdfFiles.push({
                        "filename": filename,
                        "sizeBytes": entry.size,
                        "downloadPath": "/v1/pdfs/" + filename
                    });
                }
            }
        }

        log:printInfo("Found " + pdfFiles.length().toString() + " PDF files");
        return {"pdfs": pdfFiles, "count": pdfFiles.length()};
    }

    // Download a specific PDF by filename
    resource function get pdfs/[string filename](http:Request req) returns http:Response|error {
        // Prevent path traversal attacks
        if filename.includes("..") || filename.includes("/") || filename.includes("\\") {
            http:Response badRequest = new;
            badRequest.statusCode = 400;
            badRequest.setJsonPayload({"error": "Invalid filename"});
            return badRequest;
        }

        string|http:HeaderNotFoundError apiKeyHeader = req.getHeader("X-API-Key");
        if apiKeyHeader is string && apiKeyHeader != "" && apiKeyHeader != MOCK_API_KEY {
            http:Response unauthorized = new;
            unauthorized.statusCode = 401;
            unauthorized.setJsonPayload({"error": "Invalid API key"});
            return unauthorized;
        }

        string filePath = POLICIES_DIR + filename;
        boolean|file:Error exists = file:test(filePath, file:EXISTS);
        if exists is file:Error || !exists {
            http:Response notFound = new;
            notFound.statusCode = 404;
            notFound.setJsonPayload({"error": "File not found: " + filename});
            return notFound;
        }

        log:printInfo("Serving PDF: " + filename);
        byte[]|io:Error fileBytes = io:fileReadBytes(filePath);
        if fileBytes is io:Error {
            return error("Failed to read file: " + fileBytes.message());
        }

        http:Response response = new;
        response.setHeader("Content-Type", "application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        response.setBinaryPayload(fileBytes);
        return response;
    }
}
