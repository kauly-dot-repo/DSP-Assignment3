
import ballerinax/kafka;
//import ballerina/lang.'string;
import ballerina/log;
import ballerina/io;

//Consumer 1
kafka:ConsumerConfiguration consConf = {
    bootstrapServers: "localhost:9092",
    groupId: "hdc",

    topics: ["fieapprovedproposal"],
    pollingIntervalInMillis: 1000, 
    //keyDeserializerType: kafka:DES_INT,
    //valueDeserializerType: kafka:DES_STRING,
    autoCommit: false
};

@docker:Expose {}

@docker:Config {
    name: "hdcConsumer",
    tag: "v1.0"
}

listener kafka:Listener cons = new (consConf);

service kafka:Service on cons {
    remote function onConsumerRecord(kafka:Caller caller,
                                kafka:ConsumerRecord[] records) {
        foreach var kafkaRecord in records {
            processKafkaRecord(kafkaRecord);
        }

        var commitResult = caller->commit();

        if (commitResult is error) {
            log:printError("Error occurred while committing the " +
                "offsets for the consumer ", err = commitResult);
        }
    }
}

function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    byte[] value = kafkaRecord.value;
    string|error messageContent = string:fromBytes(value);

    io:println("Student: ",messageContent, " approved");

    
    if (messageContent is string) {
            string jsonFilePath = "./files/" +messageContent+".json";
            //read file

            json readJson = checkpanic io:fileReadJson(jsonFilePath);
            io:println("***** view proposal ******");
            io:println(readJson);
        

                
       // log:print("Value: " + messageContent);
    } else {
        log:printError("Invalid value type received");
    }
}