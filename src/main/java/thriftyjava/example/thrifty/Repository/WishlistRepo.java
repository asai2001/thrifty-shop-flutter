package thriftyjava.example.thrifty.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import thriftyjava.example.thrifty.Entity.Wishlist;

import javax.transaction.Transactional;

@Repository
@Transactional
public interface WishlistRepo extends JpaRepository<Wishlist, Integer> {
    Wishlist findByWishlistId(int wishlistId);
}
