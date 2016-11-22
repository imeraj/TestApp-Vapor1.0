$(document).ready(function() {
          $("#logout").click(function() {
             $.ajax({
                    type: "GET",
                    url: "/logout",
                    // data: JSON.stringify(data),
                    contentType: "application/json; charset=utf-8",
                    crossDomain: true,
                    dataType: "json",
                    success: function (data, status, jqXHR) {
                    console.log(data);
                    location.href = '/login';
                    },
                    error: function (jqXHR, status) {
                    // error handler
                    var message = jqXHR.responseText;
                    alert(message);
                    console.log(jqXHR.responseText);

                    }
                    });


             });




 $("#addbird").click(function() {
                      var birdname = $("#bird").val();
                      console.log(birdname)

                      if ( birdname == ''  ) {
                      alert("Please fill all fields");
                      }  else {
                      var data = {
                      birdname : birdname
                      }
                      $.ajax({
                             type: "POST",
                             url: "/v1/sightings?bird="+data.birdname,
                             contentType: "application/json; charset=utf-8",
                             crossDomain: true,
                             dataType: "json",
                             success: function (data, status, jqXHR) {

                                 console.log(data.message);
                                 console.log(jqXHR.responseText);
                                 $("#bird").val('');


                             },

                             error: function (jqXHR, status) {
                                 // error handler
                                 console.log(jqXHR.responseText);
                                 alert(jqXHR.responseText);
                                 $("#bird").val('');
                                 // alert('fail' + status.code);
                             }
                             });

                      }
                      });
});
