package less.green.openpudo.persistence.dao;

import java.io.Serializable;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

public abstract class BaseEntityDao<E extends Serializable, K> {

    @PersistenceContext
    EntityManager em;

    private final Class<E> entityClass;
    private final String keyColumnName;

    public BaseEntityDao(Class<E> entityClass, String keyColumnName) {
        this.entityClass = entityClass;
        this.keyColumnName = keyColumnName;
    }

    public void flush() {
        em.flush();
    }

    public E get(K key) {
        return em.find(entityClass, key);
    }

    public void persist(E ent) {
        em.persist(ent);
    }

    public E merge(E ent) {
        return em.merge(ent);
    }

    public int delete(K key) {
        String qs = "DELETE FROM " + entityClass.getSimpleName() + " t WHERE t." + keyColumnName + " = :key";
        Query q = em.createQuery(qs);
        q.setParameter("key", key);
        int cnt = q.executeUpdate();
        return cnt;
    }

    public void remove(E ent) {
        em.remove(ent);
    }

}
