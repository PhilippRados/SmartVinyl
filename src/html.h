const char index_html[]  = R"rawliteral(

<html>
	<style>
		body {
		text-align: center;
		font-family: "Trebuchet MS", Arial;
		margin-left:auto;
		margin-right:auto;
		}
		.slider {
		width: 300px;
		}
	</style>
	<body>
		<h1>Value: <span id="servoPos">90</span></h1>

		<div>
			<input type="range" min="0" max="180" value="90" class="slider" id="myRange" onchange=getSliderValue(this.value)>
		</div>
		<button type="button" id="needle_pos_button">Change Needle Pos</button>
		<h3>Current Arm-status</h3>
		<button onclick="toggleArmButtonText()"><span id="toggleText">OFF</span></button>
		<button id="toggle_button">Change Status</button>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
		<script>
			servo_pos = document.getElementById("servoPos");
			toggle_text = document.getElementById("toggleText");

			function getSliderValue(value){
				pos = value;
				servo_pos.innerHTML = value;
			}
			
			function toggleArmButtonText(){
				text_val = toggle_text.innerText;
				if (text_val == "ON"){
					text_val = "OFF";
				} else {
					text_val = "ON";
				}
				toggle_text.innerText = text_val;
			}
			//needle-pos-request
			$(document).ready(function(){
			  $("#needle_pos_button").click(function(){
				$.get("?needlevalue=" + pos + "&", function(data, status){
				  alert("Data: " + pos);
				});
			  });
			});

			//change arm-toggle-request
			$(document).ready(function(){
			  $("#toggle_button").click(function(){
				$.get("?armstatus=" + toggle_text.innerHTML + "&", function(data, status){
				  alert("Data: " + toggle_text.innerHTML);
				});
			  });
			});	
		</script>
	</body>
</html>
)rawliteral";