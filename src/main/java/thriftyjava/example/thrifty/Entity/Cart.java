package thriftyjava.example.thrifty.Entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "cart")
public class Cart {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cartId")
    int cartId;

    @ManyToOne()
    @JoinColumn(name = "id")
    private Product product;

    public Cart(Product product) {
        this.product = product;

    }

    public Cart(){
        super();
    }
}
