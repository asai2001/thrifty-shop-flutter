package thriftyjava.example.thrifty.Entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.util.Date;

@Setter
@Getter
@Entity
@Table(name = "wishlist")
public class Wishlist {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "wishlistId")
    private int wishlistId;

    @ManyToOne()
    @JoinColumn(name = "id")
    private Product product;

    public Wishlist(Product product) {
        this.product = product;

    }

    public Wishlist(){
        super();
    }

}

