
import ballerinax/kafka;
import ballerina/log;
import ballerina/io;

//Consumer 1
kafka:ConsumerConfiguration consConf = {
    bootstrapServers: "localhost:9092",
    groupId: "vote",

    topics: ["application_form","student_proposal"],
    pollingIntervalInMillis: 1000, 
    //keyDeserializerType: kafka:DES_INT,
    //valueDeserializerType: kafka:DES_STRING,
    autoCommit: false
};


@docker:Expose {}

@docker:Config {
    name: "supervisorConsumer",
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
    if(kafkaRecord.offset.partition.topic == "student_proposal"){
         io:println("*********Supervisor*********");
            byte[] value = kafkaRecord.value;
            string|error messageContent = string:fromBytes(value);
            
            if (messageContent is string) {
                log:print("Value: " + messageContent);
            } else {
                log:printError("Invalid value type received");
            }
    }else{
          io:println("*********All applications*********");
            byte[] value = kafkaRecord.value;
            string|error messageContent = string:fromBytes(value);
            
            if (messageContent is string) {
                log:print("Value: " + messageContent);
            } else {
                log:printError("Invalid value type received");
            }
    }
}