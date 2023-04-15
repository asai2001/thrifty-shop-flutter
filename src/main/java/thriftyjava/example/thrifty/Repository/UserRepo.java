package thriftyjava.example.thrifty.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import thriftyjava.example.thrifty.Entity.UserEntity;

@Repository
public interface UserRepo extends JpaRepository<UserEntity, Integer> {
    UserEntity findById(int id);
    UserEntity findByEmailAndPassword(String email, String password);
}
