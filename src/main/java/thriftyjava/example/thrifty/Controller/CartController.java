package thriftyjava.example.thrifty.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import thriftyjava.example.thrifty.Entity.Cart;
import thriftyjava.example.thrifty.Entity.Product;
import thriftyjava.example.thrifty.Entity.Wishlist;
import thriftyjava.example.thrifty.Repository.CartRepo;
import thriftyjava.example.thrifty.Repository.ProductRepo;

@CrossOrigin("*")
@RestController
public class CartController {
    @Autowired
    CartRepo cartRepo;

    @Autowired
    ProductRepo productRepo;

    @PostMapping("cart/create")
    public ResponseEntity<?> create(Product product){
        Cart cart = new Cart(product);
        cart.setProduct(productRepo.findById(cart.getProduct().getId()));
        return ResponseEntity.ok(cartRepo.save(cart));
    }


    @GetMapping("cart/find-all")
    public ResponseEntity<?> findAll(){
        return ResponseEntity.ok(cartRepo.findAll());
    }

    @DeleteMapping("cart/delete/{cartId}")
    public String delete(@PathVariable int cartId){
        Cart cart = cartRepo.findByCartId(cartId);
        cartRepo.delete(cart);
        return "berhasil delete";
    }

}
