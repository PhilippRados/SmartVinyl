const char index_html[]  = R"rawliteral(


<html>
	<style>
		body {
			display: flex;
			text-align: center;
			color: white;
			font-family: "Trebuchet MS", Arial;
			margin-left:auto;
			margin: 0;
			margin-right:auto;
			background-image: url("https://i.ibb.co/KXh2MXS/iu.png");
			background-repeat: no-repeat;
			background-size: cover;
		}
		.container{
			position: relative;
			height:100%;
			width:60%;
			margin:0%
		}
		
		input[type=range] {
			-webkit-appearance: none;
			transform:rotate(180deg);
		}
		#myRange::-webkit-slider-thumb{
			height: 100px;
			width: 60px;
			border-radius: 3px;
			background-color: transparent;
			background: url("https://i.ibb.co/DCvbp96/cartridge.png") center no-repeat;
			transform: rotate(-90deg);
			background-size:contain ;
			cursor: pointer;
			-webkit-appearance: none;
		}
		.slider{
			position: relative;
			width: 64.5%;
			height: 0.5%;
			top: 50%;
			right: 0%;
			left:12%;
			z-index: 3;
		}
		#vinyl{
			filter:drop-shadow(30px 10px 8px rgba(0, 0, 0, 0.4));
			position: relative;
			left:0%;
			height:100%;
			width:100%
		}
		.right-container{
			width: 40%;
			margin:0px;
			padding-top: 20%;
		}
		.form{
			background: #3B484E;
			margin:10%;
			padding:20%;
			padding-top:10%;
			padding-bottom:40%;
			border-radius: 2%;
			box-shadow: 10px 10px 5px black;
		}
		#pause_button{
			height: 8%;
			padding: 5%;
		}
	</style>
	<body>
		<div class="container">
			<input type="range" min="123" max="169" value="123" class="slider" id="myRange" onchange=getSliderValue(this.value)>
			<img src="https://i.ibb.co/J7SJ1jF/vinyl.png" id="vinyl">
		</div>
		<div class="right-container">
			<div class="form">			
				<h1>Value: <span id="servoPos">123</span></h1>
				<button type="button" id="needle_pos_button">Change Needle Pos</button>
				<h3>Current Arm-status</h3>
				<img src="https://i.ibb.co/Gd5KCBk/start.png" id="pause_button">
			</div>
		</div>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
		<script>
			servo_pos = document.getElementById("servoPos");
			toggle_text = document.getElementById("toggleText");

			$('#pause_button').click(function(){
				if ($('#pause_button').attr('src') == 'https://i.ibb.co/Gd5KCBk/start.png'){
					$('#pause_button').attr('src',"https://i.ibb.co/BzqqHZK/pause.png");

					$.get("?armstatus=" + "ON" + "&", function(data, status){
						alert("Data: " + "ON");
					});
				} else {
					$('#pause_button').attr('src',"https://i.ibb.co/Gd5KCBk/start.png");

					$.get("?armstatus=" + "OFF" + "&", function(data, status){
						alert("Data: " + "OFF");
					});
				}
			})

			function getSliderValue(value){
				pos = value;
				servo_pos.innerHTML = value;
			}
			
			//needle-pos-request
			$(document).ready(function(){
			  $("#needle_pos_button").click(function(){
				if ($('#pause_button').attr('src') == 'https://i.ibb.co/Gd5KCBk/start.png'){
					$.get("?needlevalue=" + pos + "&", function(data, status){
						alert("Data: " + pos);
					});
				} else {
					alert("Cant change Needle when Music is playing");
				}});
			});
		</script>
	</body>
</html>
)rawliteral";