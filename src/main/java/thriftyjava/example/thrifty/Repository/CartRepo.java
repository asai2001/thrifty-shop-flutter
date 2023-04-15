package thriftyjava.example.thrifty.Repository;

import lombok.Data;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import thriftyjava.example.thrifty.Entity.Cart;

import javax.transaction.Transactional;

@Repository
@Transactional
public interface CartRepo extends JpaRepository<Cart, Integer> {
    Cart findByCartId(int cartId);
}
