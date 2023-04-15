package thriftyjava.example.thrifty.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import thriftyjava.example.thrifty.Entity.Product;
import thriftyjava.example.thrifty.Repository.ProductRepo;

@CrossOrigin(origins = "*")
@RestController
public class ProductController {

    @Autowired
    ProductRepo productRepo;
    @PostMapping("product/create")
    public ResponseEntity<?> createdProduct(Product product){
        return ResponseEntity.ok(productRepo.save(product));
    }

    @GetMapping("product/find-all")
    public ResponseEntity<?> findAll(){
        return ResponseEntity.ok(productRepo.findAll());
    }
}
