package thriftyjava.example.thrifty.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import thriftyjava.example.thrifty.Entity.UserEntity;
import thriftyjava.example.thrifty.Repository.UserRepo;

import java.util.HashMap;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
public class UserController {

    @Autowired
    UserRepo userRepo;

    @PostMapping("user/create")
    public ResponseEntity<?> createuser(UserEntity user){
        return ResponseEntity.ok(userRepo.save(user));
    }

    @GetMapping("user/get-by-id/{id}")
    public ResponseEntity<?> getUser(@PathVariable("id") int id){
        UserEntity find = userRepo.findById(id);
        return new ResponseEntity<>(find, HttpStatus.OK);
    }

    @GetMapping("user/get-by-ep/{email}&{password}")
    public ResponseEntity<?> getUserString(@PathVariable("email") String email,
                                           @PathVariable("password") String password) {
        UserEntity find = userRepo.findByEmailAndPassword(email, password);
            Map<String, String> map = new HashMap<>();
            Map<String, Object> map1 = new HashMap<>();
            map.put("email", find.getEmail());
            map.put("password", find.getPassword());
//            map.put("status", "success");
            map1.put("status", "success");
            map1.put("data", map);
            return ResponseEntity.ok(map1);
    }
}
