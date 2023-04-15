package thriftyjava.example.thrifty.Controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import thriftyjava.example.thrifty.Entity.Product;
import thriftyjava.example.thrifty.Entity.Wishlist;
import thriftyjava.example.thrifty.Repository.ProductRepo;
import thriftyjava.example.thrifty.Repository.WishlistRepo;

import java.util.List;

@CrossOrigin("*")
@RestController
public class WishlistController {
    @Autowired
    WishlistRepo wishlistRepo;

    @Autowired
    ProductRepo productRepo;

    @PostMapping("wishlist/create")
    public ResponseEntity<?> create(Product product){
        Wishlist wishlist = new Wishlist(product);
        wishlist.setProduct(productRepo.findById(wishlist.getProduct().getId()));
        return ResponseEntity.ok(wishlistRepo.save(wishlist));
    }

    @GetMapping("wishlist/find-all")
    public List<Wishlist> showAll() {
        return wishlistRepo.findAll();
    }

    @DeleteMapping("wishlist/delete/{wishlistId}")
    public String delete(@PathVariable int wishlistId){
        Wishlist wishlist = wishlistRepo.findByWishlistId(wishlistId);
        wishlistRepo.delete(wishlist);
        return "berhasil delete";
    }

}
