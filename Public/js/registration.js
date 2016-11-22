$(document).ready(function() {
        $("#register").click(function() {
           var email = $("#email").val();
            console.log(email)
           var password = $("#password").val();
           if ( email == '' || password == '' ) {
           alert("Please fill all fields...!!!!!!");
         }  else {
             var data = {
                 userName : email,
                 password: password
               }
               $.ajax({
                       type: "POST",
                       url: "/register",
                       data: data, // data: JSON.stringify(data),
                       contentType: "application/json; charset=utf-8",
                       crossDomain: true,

                       dataType: "json",
                        success: function (data, status, jqXHR) {

                            console.log(data.message)
                            console.log(jqXHR.responseText)
                            location.href = '/login';

                       },
                       beforeSend: function (xhr) {
                           xhr.setRequestHeader ("Authorization", "Basic " + btoa(data.userName + ":" + data.password));

                       },
                       error: function (jqXHR, status) {
                           // error handler
                           console.log(jqXHR.responseText);
                          // alert('fail' + status.code);
                       }
                   });

           }
    });
});
