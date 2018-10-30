var pauseLabel = '&#10074;&#10074;';
var playLabel  = '&#9658;';

function toggleAudio(el) {
	var audio = el.parentNode.querySelector('audio');
	if (audio.paused || audio.ended) {
		el.title = 'pause';
		el.innerHTML = pauseLabel;
		audio.play();
	}
	else {
		el.title = 'play';
		el.innerHTML = playLabel;
		audio.pause();
	}
	audio.addEventListener('ended', function() { el.innerHTML = playLabel; });
}
