// worker.js

function onModuleReady(SBAGEN) {
    self.onmessage = function(e) {
      var data = e.data;
      var func = data.function;
      var args = data.arguments;

    if (func === 'start') {
      start(SBAGEN,args[0],args[1]);
    }

    if (func === 'stop') {
      stop(SBAGEN);
    }
  }
};

function start(SBAGEN,sequence,buffer) {
  var rate = 44100;
  var init = SBAGEN._sbagen_init();
  var parameters = SBAGEN._sbagen_set_parameters(rate, 0, 0, null);
  var sequence = SBAGEN._sbagen_parse_seq(sequence);
  var run = SBAGEN._sbagen_run();
  SBAGEN.sbagen_free_seq();
	SBAGEN.sbagen_exit();
}
function stop(SBAGEN) {
  SBAGEN.sbagen_free_seq();
	SBAGEN.sbagen_exit();
}


function onError(err) {
  return postMessage({
      id: this["data"]["id"],
      error: err["message"]
  });
}

if (typeof importScripts === "function") {
  db = null;
  var sbagenModuleReady = initSbaGenJs();
  self.onmessage = function onmessage(event) {
      return sbagenModuleReady
          .then(onModuleReady.bind(event))
          .catch(onError.bind(event));
  };
}