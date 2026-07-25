<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

$curl = curl_init();    
$API_KEY = getenv("OPENAI_API_KEY");

if (!$API_KEY) {
    http_response_code(500);
    echo json_encode(["error" => "The server is not configured."]);
    exit;
}

$url = "https://api.openai.com/v1/chat/completions";
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_POST, true);

$headers = array( // cUrl headers (-H)
    "Content-Type: application/json",
    "Authorization: Bearer $API_KEY"
);

curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);


$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE); //convert JSON into array


$content = "Check grammar of the text and return only the corrected result without any remarks: ".$input['text'];

$data = array( // cUrl data
    "model"=> "gpt-4",
    "messages" => array(array("role" => "user", "content" => $content)), 
    "temperature" => 0.5,
    "max_tokens" => 100,
    "top_p" => 1,
    "frequency_penalty" => 0,
    "presence_penalty" => 0
);
curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));

 $response = curl_exec($curl);               // execute cURL
 $response = json_decode($response, true);   // extract json from response

$generated_text = $response['choices'][0]['message']['content'];  // extract first response from json

//$generated_text = $_GET;
echo json_encode(['correctedText' => $generated_text]);


curl_close($curl);      // close cURL session
?>
